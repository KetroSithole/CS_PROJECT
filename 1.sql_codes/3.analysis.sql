USE UniversityDW;
GO

---------------------------------------------------------
-- 1. Total modules per year
---------------------------------------------------------
SELECT 'Year 1' AS YearLevel, COUNT(*) AS TotalModules
FROM dbo.DW_Year1Modules
UNION ALL
SELECT 'Year 2', COUNT(*) 
FROM dbo.DW_Year2Modules
UNION ALL
SELECT 'Year 3', COUNT(*) 
FROM dbo.DW_Year3Modules;
GO

---------------------------------------------------------
-- 2. Total credits per year
---------------------------------------------------------
SELECT 'Year 1' AS YearLevel, SUM(Credits) AS TotalCredits
FROM dbo.DW_Year1Modules
UNION ALL
SELECT 'Year 2', SUM(Credits)
FROM dbo.DW_Year2Modules
UNION ALL
SELECT 'Year 3', SUM(Credits)
FROM dbo.DW_Year3Modules;
GO

---------------------------------------------------------
-- 3. Category breakdown per year 
-- (Fundamental vs Core vs Elective)
---------------------------------------------------------
SELECT 'Year 1' AS YearLevel, Category, COUNT(*) AS Total
FROM dbo.DW_Year1Modules
GROUP BY Category
UNION ALL
SELECT 'Year 2', Category, COUNT(*) 
FROM dbo.DW_Year2Modules
GROUP BY Category
UNION ALL
SELECT 'Year 3', Category, COUNT(*) 
FROM dbo.DW_Year3Modules
GROUP BY Category;
GO

---------------------------------------------------------
-- 4. Find duplicated module codes across the entire DW
---------------------------------------------------------
WITH AllMods AS (
    SELECT ModuleCode FROM dbo.DW_Year1Modules
    UNION ALL
    SELECT ModuleCode FROM dbo.DW_Year2Modules
    UNION ALL
    SELECT ModuleCode FROM dbo.DW_Year3Modules
)
SELECT ModuleCode, COUNT(*) AS DuplicateCount
FROM AllMods
GROUP BY ModuleCode
HAVING COUNT(*) > 1;
GO

---------------------------------------------------------
-- 5. Union of all modules (consolidated dataset)
---------------------------------------------------------
SELECT 'Year 1' AS YearLevel, ModuleCode, ModuleName, Credits, Category, LoadDate
FROM dbo.DW_Year1Modules
UNION ALL
SELECT 'Year 2', ModuleCode, ModuleName, Credits, Category, LoadDate
FROM dbo.DW_Year2Modules
UNION ALL
SELECT 'Year 3', ModuleCode, ModuleName, Credits, Category, LoadDate
FROM dbo.DW_Year3Modules;
GO

---------------------------------------------------------
-- 6. Most credit-heavy modules per year
---------------------------------------------------------
SELECT TOP 5 'Year 1' AS YearLevel, ModuleCode, ModuleName, Credits
FROM dbo.DW_Year1Modules
ORDER BY Credits DESC;

SELECT TOP 5 'Year 2' AS YearLevel, ModuleCode, ModuleName, Credits
FROM dbo.DW_Year2Modules
ORDER BY Credits DESC;

SELECT TOP 5 'Year 3' AS YearLevel, ModuleCode, ModuleName, Credits
FROM dbo.DW_Year3Modules
ORDER BY Credits DESC;
GO

---------------------------------------------------------
-- 7. Category distribution totals across all years
---------------------------------------------------------
WITH AllMods AS (
    SELECT Category FROM dbo.DW_Year1Modules
    UNION ALL
    SELECT Category FROM dbo.DW_Year2Modules
    UNION ALL
    SELECT Category FROM dbo.DW_Year3Modules
)
SELECT Category, COUNT(*) AS TotalModules
FROM AllMods
GROUP BY Category;
GO

---------------------------------------------------------
-- 8. Modules that appear in more than one year
---------------------------------------------------------
WITH AllMods AS (
    SELECT ModuleCode, 'Year 1' AS YearLevel FROM dbo.DW_Year1Modules
    UNION ALL
    SELECT ModuleCode, 'Year 2' FROM dbo.DW_Year2Modules
    UNION ALL
    SELECT ModuleCode, 'Year 3' FROM dbo.DW_Year3Modules
)
SELECT ModuleCode, COUNT(*) AS AppearsInHowManyYears
FROM AllMods
GROUP BY ModuleCode
HAVING COUNT(*) > 1;
GO
