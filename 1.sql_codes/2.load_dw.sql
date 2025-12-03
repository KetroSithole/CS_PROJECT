---------------------------------------------------------
-- CREATE DATA WAREHOUSE DATABASE (IF NOT EXISTS)
---------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'UniversityDW')
BEGIN
    CREATE DATABASE UniversityDW;
END
GO

USE UniversityDW;
GO

---------------------------------------------------------
-- CREATE DW TABLES (IF NOT EXISTS)
-- Structure similar to staging, plus LoadDate
---------------------------------------------------------

-- Year 1 DW table
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'dbo.DW_Year1Modules') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE dbo.DW_Year1Modules (
        DW_ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleCode VARCHAR(20),
        ModuleName VARCHAR(200),
        Credits DECIMAL(5,2),
        Category VARCHAR(50),
        LoadDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- Year 2 DW table
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'dbo.DW_Year2Modules') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE dbo.DW_Year2Modules (
        DW_ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleCode VARCHAR(20),
        ModuleName VARCHAR(200),
        Credits DECIMAL(5,2),
        Category VARCHAR(50),
        LoadDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- Year 3 DW table
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'dbo.DW_Year3Modules') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE dbo.DW_Year3Modules (
        DW_ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleCode VARCHAR(20),
        ModuleName VARCHAR(200),
        Credits DECIMAL(5,2),
        Category VARCHAR(50),
        LoadDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO


---------------------------------------------------------
-- LOAD DATA FROM STAGING INTO DATA WAREHOUSE
-- Only insert rows that are NOT already in DW (no duplicates)
---------------------------------------------------------

-------------------------
-- YEAR 1 → DW_Year1Modules
-------------------------
INSERT INTO UniversityDW.dbo.DW_Year1Modules (ModuleCode, ModuleName, Credits, Category)
SELECT s.ModuleCode,
       s.ModuleName,
       s.Credits,
       s.Category
FROM UniversityStagingDB.dbo.Year1Modules AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM UniversityDW.dbo.DW_Year1Modules AS d
    WHERE d.ModuleCode = s.ModuleCode
);
GO

-------------------------
-- YEAR 2 → DW_Year2Modules
-------------------------
INSERT INTO UniversityDW.dbo.DW_Year2Modules (ModuleCode, ModuleName, Credits, Category)
SELECT s.ModuleCode,
       s.ModuleName,
       s.Credits,
       s.Category
FROM UniversityStagingDB.dbo.Year2Modules AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM UniversityDW.dbo.DW_Year2Modules AS d
    WHERE d.ModuleCode = s.ModuleCode
);
GO

-------------------------
-- YEAR 3 → DW_Year3Modules
-------------------------
INSERT INTO UniversityDW.dbo.DW_Year3Modules (ModuleCode, ModuleName, Credits, Category)
SELECT s.ModuleCode,
       s.ModuleName,
       s.Credits,
       s.Category
FROM UniversityStagingDB.dbo.Year3Modules AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM UniversityDW.dbo.DW_Year3Modules AS d
    WHERE d.ModuleCode = s.ModuleCode
);
GO
