---------------------------------------------------------
-- CREATE STAGING DATABASE
---------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'UniversityStagingDB')
BEGIN
    CREATE DATABASE UniversityStagingDB;
END
GO

USE UniversityStagingDB;
GO

---------------------------------------------------------
-- CREATE TABLE: Year1Modules
---------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'UniversityStagingDB.dbo.Year1Modules') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE UniversityStagingDB.dbo.Year1Modules (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleCode VARCHAR(20),
        ModuleName VARCHAR(200),
        Credits DECIMAL(5,2),
        Category VARCHAR(50),
        DateInserted DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

---------------------------------------------------------
-- CREATE TABLE: Year2Modules
---------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'UniversityStagingDB.dbo.Year2Modules') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE UniversityStagingDB.dbo.Year2Modules (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleCode VARCHAR(20),
        ModuleName VARCHAR(200),
        Credits DECIMAL(5,2),
        Category VARCHAR(50),
        DateInserted DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

---------------------------------------------------------
-- CREATE TABLE: Year3Modules
---------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'UniversityStagingDB.dbo.Year3Modules') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE UniversityStagingDB.dbo.Year3Modules (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleCode VARCHAR(20),
        ModuleName VARCHAR(200),
        Credits DECIMAL(5,2),
        Category VARCHAR(50),
        DateInserted DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO


---------------------------------------------------------
-- INSERT YEAR 1 MODULES
---------------------------------------------------------
INSERT INTO UniversityStagingDB.dbo.Year1Modules 
    (ModuleCode, ModuleName, Credits, Category) VALUES
('AIM 111','Academic information management 111',4.00,'Fundamental'),
('AIM 121','Academic information management 121',4.00,'Fundamental'),
('ALL 121','Academic literacy for Information Technology 121',6.00,'Fundamental'),
('UPO 112','Academic orientation 112',0.00,'Fundamental'),

('COS 110','Program design: Introduction 110',16.00,'Core'),
('COS 122','Operating systems 122',16.00,'Core'),
('COS 132','Imperative programming 132',16.00,'Core'),
('COS 151','Introduction to computer science 151',8.00,'Core'),
('WTW 114','Calculus 114',16.00,'Core'),
('WTW 115','Discrete structures 115',8.00,'Core'),
('WTW 124','Mathematics 124',16.00,'Core'),
('WTW 134','Mathematics 134',16.00,'Core'),
('WTW 146','Linear algebra 146',8.00,'Core'),
('WTW 148','Calculus 148',8.00,'Core'),
('WTW 152','Mathematical modelling 152',8.00,'Core'),
('WTW 162','Dynamical processes 162',8.00,'Core'),

('BOT 161','Plants and society 161',8.00,'Elective'),
('CMY 117','General chemistry 117',16.00,'Elective'),
('CMY 127','General chemistry 127',16.00,'Elective'),
('ENV 101','Introduction to environmental sciences 101',8.00,'Elective'),
('GGY 156','Aspects of human geography 156',8.00,'Elective'),
('GGY 168','Introduction to physical geography 168',12.00,'Elective'),
('GLY 155','Introduction to geology 155',16.00,'Elective'),
('GLY 163','Earth history 163',16.00,'Elective'),
('GMC 110','Cartography 110',10.00,'Elective'),
('MBY 161','Introduction to microbiology 161',8.00,'Elective'),
('MLB 111','Molecular and cell biology 111',16.00,'Elective'),
('PHY 114','First course in physics 114',16.00,'Elective'),
('PHY 124','First course in physics 124',16.00,'Elective'),
('PHY 131','Physics for biology students 131',16.00,'Elective'),
('SCI 154','Exploring the universe 154',16.00,'Elective'),
('STC 122','Statistics 122',13.00,'Elective'),
('STK 110','Statistics 110',13.00,'Elective'),
('STK 120','Statistics 120',13.00,'Elective'),
('WST 111','Mathematical statistics 111',16.00,'Elective'),
('WST 121','Mathematical statistics 121',16.00,'Elective');
GO


---------------------------------------------------------
-- INSERT YEAR 2 MODULES
---------------------------------------------------------
INSERT INTO UniversityStagingDB.dbo.Year2Modules 
    (ModuleCode, ModuleName, Credits, Category) VALUES
('JCP 202','Community-based project 202',8.00,'Fundamental'),

('COS 210','Theoretical computer science 210',8.00,'Core'),
('COS 212','Data structures and algorithms 212',16.00,'Core'),
('COS 214','Software modelling 214',16.00,'Core'),
('COS 216','Netcentric computer systems 216',16.00,'Core'),
('COS 221','Introduction to database systems 221',16.00,'Core'),
('COS 226','Concurrent systems 226',16.00,'Core'),
('COS 284','Computer organisation and architecture 284',16.00,'Core'),
('WTW 285','Discrete structures 285',12.00,'Core'),

('STK 210','Statistics 210',20.00,'Elective'),
('STK 220','Statistics 220',20.00,'Elective'),
('WST 211','Mathematical statistics 211',24.00,'Elective'),
('WST 212','Applications in data science 212',12.00,'Elective'),
('WST 221','Mathematical statistics 221',24.00,'Elective');
GO

---------------------------------------------------------
-- INSERT YEAR 3 MODULES
---------------------------------------------------------
INSERT INTO UniversityStagingDB.dbo.Year3Modules 
    (ModuleCode, ModuleName, Credits, Category) VALUES
('COS 301','Software engineering 301',27.00,'Core'),
('COS 330','Computer security and ethics 330',18.00,'Core'),
('COS 332','Computer networks 332',18.00,'Core'),
('COS 333','Programming languages 333',18.00,'Core'),
('COS 341','Compiler construction 341',18.00,'Core'),

('COS 314','Artificial intelligence 314',18.00,'Elective'),
('COS 326','Database systems 326',18.00,'Elective'),
('COS 344','Computer graphics 344',18.00,'Elective'),
('IMY 310','Human-computer interaction 310',25.00,'Elective'),
('IMY 320','Multimedia 320',25.00,'Elective'),
('STK 353','The science of data analytics 353',18.00,'Elective');
GO
