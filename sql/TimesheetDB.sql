/*
===============================================================================
Project : Employee Timesheet Management System
Author  : Floriana Berbecel
===============================================================================
*/



/*pas 1: create db*/

USE master;
GO

IF db_id('TimesheetDB') IS NOT NULL  /*avoid errors if the script is executed multipe times*/
BEGIN 
ALTER DATABASE TimesheetDB SET single_user WITH ROLLBACK IMMEDIATE;
DROP DATABASE TimesheetDB;
END;
GO

CREATE DATABASE TimesheetDB;
GO

USE TimesheetDB;
GO

SELECT db_name() as CurrentDatabase;
GO

/*PAS2: INDEPENDENT TABLES 
departments,clients,taskcategories,worklocations,employees,projects,timesheets,timesheetsentries,leavequest,auditlogs*/

/*DEPARTMENTS*/
CREATE TABLE Departments
(
 DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
 DepartmentName NVARCHAR(100) NOT NULL,
 ManagerName NVARCHAR(100) NOT NULL,
 IsActive BIT NOT NULL CONSTRAINT DF_Departments_IsActive DEFAULT(1),
 CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Departments_CreatedAt DEFAULT(SYSDATETIME()),
 CONSTRAINT UQ_Department_Name UNIQUE(DepartmentName),
 CONSTRAINT CK_Department_Name CHECK(LEN(DepartmentName) >= 3)
);
GO

/*CLIENTS - externalclients for which projects are delivered*/ 
CREATE TABLE Clients
(
ClientID INT IDENTITY(1,1) PRIMARY KEY,
ClientName NVARCHAR(150) NOT NULL,
Country NVARCHAR(100) NOT NULL,
Industry NVARCHAR(100) NULL,
IsActive BIT NOT NULL CONSTRAINT DF_Clients_IsActive DEFAULT(1),
CONSTRAINT UQ_Client_Name UNIQUE(ClientName)
);
GO

/*TaskCategories*/
CREATE TABLE TaskCategories
(
CategoryID INT IDENTITY(1,1) PRIMARY KEY,
CategoryName NVARCHAR(100) NOT NULL,
Billable BIT NOT NULL, 
CONSTRAINT UQ_Category_Name UNIQUE(CategoryName)
);
GO

/*WorkLocations*/
CREATE TABLE WorkLocations
(
LocationID INT IDENTITY(1,1) PRIMARY KEY,
LocationName NVARCHAR(100) NOT NULL,
Country NVARCHAR(100) NOT NULL,
IsRemote BIT NOT NULL,
CONSTRAINT UQ_Location_Name UNIQUE(LocationName)
);
GO


/*PAS2: DEPENDENT TABLES 
employees,projects,timesheets,timesheetsentries,leaverequests,auditlogs*/


/*EMPLOYEES*/
CREATE TABLE Employees
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    DepartmentID INT NOT NULL,
    JobTitle NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_Employees_IsActive DEFAULT(1),
    CONSTRAINT UQ_Employees_Email UNIQUE(Email),
    CONSTRAINT CK_Employees_Salary CHECK(Salary > 0),
    CONSTRAINT FK_Employees_Departments FOREIGN KEY(DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

ALTER TABLE Employees
ADD JobTitle NVARCHAR(100) NOT NULL
    CONSTRAINT DF_Employees_JobTitle DEFAULT('Software Developer');
GO

CREATE TABLE Projects
(
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName NVARCHAR(150) NOT NULL,
    ClientID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Budget DECIMAL(12,2) NOT NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Project_Status DEFAULT('Active'),
    CONSTRAINT UQ_Project_Name UNIQUE(ProjectName),
    CONSTRAINT CK_Project_Budget CHECK(Budget > 0),
    CONSTRAINT CK_Project_Dates CHECK(EndDate IS NULL OR EndDate >= StartDate),
    CONSTRAINT FK_Project_Client FOREIGN KEY(ClientID) REFERENCES Clients(ClientID)
);
GO


CREATE TABLE Timesheets
(
    TimesheetID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    WeekStart DATE NOT NULL,
    WeekEnd DATE NOT NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Timesheet_Status DEFAULT('Draft'),
    SubmittedDate DATETIME2 NULL,
    ApprovedDate DATETIME2 NULL,
    CONSTRAINT CK_Timesheet_Dates CHECK(WeekEnd >= WeekStart),
    CONSTRAINT FK_Timesheet_Employee FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID)
);
GO



CREATE TABLE TimesheetEntries
(
    EntryID INT IDENTITY(1,1) PRIMARY KEY,
    TimesheetID INT NOT NULL,
    ProjectID INT NOT NULL,
    CategoryID INT NOT NULL,
    LocationID INT NOT NULL,
    WorkDate DATE NOT NULL,
    HoursWorked DECIMAL(4,2) NOT NULL,
    WorkDescription NVARCHAR(500) NULL,
    AdditionalInfo NVARCHAR(MAX) NULL,
    CONSTRAINT CK_TimesheetEntry_Hours CHECK(HoursWorked > 0 AND HoursWorked <= 24),
    CONSTRAINT CK_TimesheetEntry_JSON  CHECK(AdditionalInfo IS NULL OR ISJSON(AdditionalInfo)=1),
    CONSTRAINT FK_Entry_Timesheet FOREIGN KEY(TimesheetID) REFERENCES Timesheets(TimesheetID),
    CONSTRAINT FK_Entry_Project FOREIGN KEY(ProjectID) REFERENCES Projects(ProjectID),
    CONSTRAINT FK_Entry_Category FOREIGN KEY(CategoryID) REFERENCES TaskCategories(CategoryID),
    CONSTRAINT FK_Entry_Location FOREIGN KEY(LocationID) REFERENCES WorkLocations(LocationID)
);
GO



CREATE TABLE LeaveRequests
(
    LeaveID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    LeaveType NVARCHAR(50) NOT NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_Leave_Status DEFAULT('Pending'),
    Reason NVARCHAR(300) NULL,
    CONSTRAINT CK_Leave_Dates CHECK(EndDate >= StartDate),
    CONSTRAINT FK_Leave_Employee FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID)
);
GO



CREATE TABLE AuditLogs
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    ActionName NVARCHAR(100) NOT NULL,
    ActionDate DATETIME2 NOT NULL CONSTRAINT DF_Audit_ActionDate DEFAULT(SYSDATETIME()),
    IPAddress VARCHAR(50) NULL,
    Details NVARCHAR(MAX) NULL,
    CONSTRAINT CK_Audit_JSON CHECK(Details IS NULL OR ISJSON(Details)=1),
    CONSTRAINT FK_Audit_Employee FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID)
);
GO


/*INSERT*/
INSERT INTO Departments (DepartmentName, ManagerName)
VALUES
('Software Development','Andrei Popescu'),
('Quality Assurance','Maria Ionescu'),
('DevOps','Alex Dumitrescu'),
('Business Analysis','Cristina Radu'),
('Project Management','Mihai Georgescu'),
('Human Resources','Elena Marin'),
('Finance','George Stoica'),
('Marketing','Ana Pavel'),
('Sales','Daniel Matei'),
('Customer Support','Ioana Tudor'),
('Infrastructure','Victor Stan'),
('Cyber Security','Robert Enache'),
('Data Engineering','Bianca Dobre'),
('Data Analytics','Paul Iacob'),
('Artificial Intelligence','Stefan Rusu'),
('Cloud Engineering','Diana Vasile'),
('Architecture','Catalin Neagu'),
('Research','Silvia Munteanu'),
('Operations','Florin Oprea'),
('Procurement','Irina Dumitru'),
('Legal','Gabriel Sandu'),
('Compliance','Monica Gheorghe'),
('Training','Ovidiu Lazar'),
('PMO','Roxana Petrescu'),
('Business Intelligence','Cosmin Tudor'),
('Technical Support','Adrian Ilie'),
('Product Management','Laura Matei'),
('Innovation','Marius Pop'),
('QA Automation','Raluca Nistor'),
('Administration','Alina Voicu');
GO

INSERT INTO Clients (ClientName, Country, Industry)
VALUES
('Microsoft','USA','Technology'),
('Oracle','USA','Technology'),
('Amazon','USA','Cloud'),
('Google','USA','Technology'),
('Bosch','Germany','Automotive'),
('BMW','Germany','Automotive'),
('ING Bank','Netherlands','Banking'),
('Raiffeisen Bank','Austria','Banking'),
('Vodafone','United Kingdom','Telecommunications'),
('Orange','France','Telecommunications'),
('Siemens','Germany','Engineering'),
('SAP','Germany','Software'),
('Adobe','USA','Software'),
('IBM','USA','Technology'),
('Intel','USA','Hardware'),
('Nokia','Finland','Telecommunications'),
('Philips','Netherlands','Healthcare'),
('Shell','United Kingdom','Energy'),
('Airbus','France','Aerospace'),
('Tesla','USA','Automotive'),
('Meta','USA','Technology'),
('Cisco','USA','Networking'),
('Dell','USA','Hardware'),
('HP','USA','Technology'),
('Accenture','Ireland','Consulting'),
('Capgemini','France','Consulting'),
('Luxoft','Switzerland','IT Services'),
('Continental','Germany','Automotive'),
('Endava','Romania','IT Services'),
('UiPath','Romania','Automation');
GO

INSERT INTO TaskCategories (CategoryName, Billable)
VALUES
('Development',1),
('Bug Fixing',1),
('Testing',1),
('Code Review',1),
('Documentation',1),
('Meeting',0),
('Research',0),
('Support',1),
('Deployment',1),
('Planning',0),
('Design',1),
('Training',0),
('Maintenance',1),
('Refactoring',1),
('Knowledge Sharing',0),
('Customer Support',1),
('Incident Resolution',1),
('Monitoring',1),
('Performance Optimization',1),
('Security Review',1),
('Data Migration',1),
('Requirement Analysis',1),
('Sprint Planning',0),
('Retrospective',0),
('Daily Standup',0),
('Technical Interview',0),
('Mentoring',0),
('Proof of Concept',1),
('Environment Setup',1),
('Release Management',1);
GO

INSERT INTO WorkLocations (LocationName, Country, IsRemote)
VALUES
('Bucharest Office','Romania',0),
('Cluj-Napoca Office','Romania',0),
('Iasi Office','Romania',0),
('Timisoara Office','Romania',0),
('Brasov Office','Romania',0),
('Constanta Office','Romania',0),
('Craiova Office','Romania',0),
('Sibiu Office','Romania',0),
('Oradea Office','Romania',0),
('Pitesti Office','Romania',0),
('Remote Romania','Romania',1),
('Remote Germany','Germany',1),
('Remote France','France',1),
('Remote Netherlands','Netherlands',1),
('Remote United Kingdom','United Kingdom',1),
('Client Site Bucharest','Romania',0),
('Client Site Munich','Germany',0),
('Client Site Paris','France',0),
('Client Site Amsterdam','Netherlands',0),
('Client Site London','United Kingdom',0),
('Data Center East','Romania',0),
('Data Center West','Germany',0),
('Cloud Environment Azure','Global',1),
('Cloud Environment AWS','Global',1),
('Cloud Environment GCP','Global',1),
('Disaster Recovery Site','Romania',0),
('Hybrid Office','Romania',0),
('Innovation Lab','Romania',0),
('Training Center','Romania',0),
('Headquarters','Romania',0);
GO

INSERT INTO Employees
(
    FirstName,
    LastName,
    Email,
    PhoneNumber,
    HireDate,
    Salary,
    DepartmentID,
    JobTitle
)
VALUES
('Floriana','Berbecel','floriana.berbecel@email.com','0711111111','2023-01-15',6500,1,'Junior Software Developer'),
('Andrei','Popescu','andrei.popescu@email.com','0721111111','2020-05-11',9800,1,'Senior Software Developer'),
('Maria','Ionescu','maria.ionescu@email.com','0731111111','2021-03-20',7600,2,'QA Engineer'),
('Alex','Dumitrescu','alex.dumitrescu@email.com','0741111111','2019-11-01',12000,3,'DevOps Engineer'),
('Cristina','Radu','cristina.radu@email.com','0751111111','2018-09-15',11500,4,'Business Analyst'),
('Mihai','Georgescu','mihai.georgescu@email.com','0761111111','2017-08-10',14000,5,'Project Manager'),
('Elena','Marin','elena.marin@email.com','0771111111','2022-04-05',7000,6,'HR Specialist'),
('George','Stoica','george.stoica@email.com','0781111111','2020-01-14',8800,7,'Financial Analyst'),
('Ana','Pavel','ana.pavel@email.com','0791111111','2021-07-01',7200,8,'Marketing Specialist'),
('Daniel','Matei','daniel.matei@email.com','0712222222','2019-06-18',8300,9,'Sales Consultant'),
('Ioana','Tudor','ioana.tudor@email.com','0722222222','2022-01-10',6500,10,'Support Engineer'),
('Victor','Stan','victor.stan@email.com','0732222222','2018-02-28',11800,11,'Infrastructure Engineer'),
('Robert','Enache','robert.enache@email.com','0742222222','2017-05-22',13500,12,'Cyber Security Engineer'),
('Bianca','Dobre','bianca.dobre@email.com','0752222222','2023-02-13',7600,13,'Data Engineer'),
('Paul','Iacob','paul.iacob@email.com','0762222222','2020-10-30',9800,14,'Data Analyst'),
('Stefan','Rusu','stefan.rusu@email.com','0772222222','2021-11-15',11200,15,'AI Engineer'),
('Diana','Vasile','diana.vasile@email.com','0782222222','2019-09-09',11600,16,'Cloud Engineer'),
('Catalin','Neagu','catalin.neagu@email.com','0792222222','2016-12-20',15500,17,'Solution Architect'),
('Silvia','Munteanu','silvia.munteanu@email.com','0713333333','2022-06-06',7300,18,'Research Engineer'),
('Florin','Oprea','florin.oprea@email.com','0723333333','2019-04-14',8900,19,'Operations Engineer'),
('Irina','Dumitru','irina.dumitru@email.com','0733333333','2020-03-17',8100,20,'Procurement Specialist'),
('Gabriel','Sandu','gabriel.sandu@email.com','0743333333','2018-07-25',9700,21,'Legal Advisor'),
('Monica','Gheorghe','monica.gheorghe@email.com','0753333333','2021-02-12',9200,22,'Compliance Officer'),
('Ovidiu','Lazar','ovidiu.lazar@email.com','0763333333','2020-09-01',8600,23,'Technical Trainer'),
('Roxana','Petrescu','roxana.petrescu@email.com','0773333333','2019-10-19',10900,24,'PMO Specialist'),
('Cosmin','Tudor','cosmin.tudor@email.com','0783333333','2022-05-08',9500,25,'BI Developer'),
('Adrian','Ilie','adrian.ilie@email.com','0793333333','2018-01-16',9100,26,'Technical Support Engineer'),
('Laura','Matei','laura.matei@email.com','0714444444','2017-04-23',13200,27,'Product Manager'),
('Marius','Pop','marius.pop@email.com','0724444444','2023-03-11',8400,28,'Innovation Engineer'),
('Raluca','Nistor','raluca.nistor@email.com','0734444444','2021-12-02',9900,29,'QA Automation Engineer');
GO

INSERT INTO Employees
(
    FirstName,
    LastName,
    Email,
    PhoneNumber,
    HireDate,
    Salary,
    DepartmentID,
    JobTitle
)
VALUES
('Floriana','Berbecel','floriana.berbecel@email.com','0711111111','2023-01-15',6500,1,'Junior Software Developer'),
('Andrei','Popescu','andrei.popescu@email.com','0721111111','2020-05-11',9800,1,'Senior Software Developer'),
('Maria','Ionescu','maria.ionescu@email.com','0731111111','2021-03-20',7600,2,'QA Engineer'),
('Alex','Dumitrescu','alex.dumitrescu@email.com','0741111111','2019-11-01',12000,3,'DevOps Engineer'),
('Cristina','Radu','cristina.radu@email.com','0751111111','2018-09-15',11500,4,'Business Analyst'),
('Mihai','Georgescu','mihai.georgescu@email.com','0761111111','2017-08-10',14000,5,'Project Manager'),
('Elena','Marin','elena.marin@email.com','0771111111','2022-04-05',7000,6,'HR Specialist'),
('George','Stoica','george.stoica@email.com','0781111111','2020-01-14',8800,7,'Financial Analyst'),
('Ana','Pavel','ana.pavel@email.com','0791111111','2021-07-01',7200,8,'Marketing Specialist'),
('Daniel','Matei','daniel.matei@email.com','0712222222','2019-06-18',8300,9,'Sales Consultant'),
('Ioana','Tudor','ioana.tudor@email.com','0722222222','2022-01-10',6500,10,'Support Engineer'),
('Victor','Stan','victor.stan@email.com','0732222222','2018-02-28',11800,11,'Infrastructure Engineer'),
('Robert','Enache','robert.enache@email.com','0742222222','2017-05-22',13500,12,'Cyber Security Engineer'),
('Bianca','Dobre','bianca.dobre@email.com','0752222222','2023-02-13',7600,13,'Data Engineer'),
('Paul','Iacob','paul.iacob@email.com','0762222222','2020-10-30',9800,14,'Data Analyst'),
('Stefan','Rusu','stefan.rusu@email.com','0772222222','2021-11-15',11200,15,'AI Engineer'),
('Diana','Vasile','diana.vasile@email.com','0782222222','2019-09-09',11600,16,'Cloud Engineer'),
('Catalin','Neagu','catalin.neagu@email.com','0792222222','2016-12-20',15500,17,'Solution Architect'),
('Silvia','Munteanu','silvia.munteanu@email.com','0713333333','2022-06-06',7300,18,'Research Engineer'),
('Florin','Oprea','florin.oprea@email.com','0723333333','2019-04-14',8900,19,'Operations Engineer'),
('Irina','Dumitru','irina.dumitru@email.com','0733333333','2020-03-17',8100,20,'Procurement Specialist'),
('Gabriel','Sandu','gabriel.sandu@email.com','0743333333','2018-07-25',9700,21,'Legal Advisor'),
('Monica','Gheorghe','monica.gheorghe@email.com','0753333333','2021-02-12',9200,22,'Compliance Officer'),
('Ovidiu','Lazar','ovidiu.lazar@email.com','0763333333','2020-09-01',8600,23,'Technical Trainer'),
('Roxana','Petrescu','roxana.petrescu@email.com','0773333333','2019-10-19',10900,24,'PMO Specialist'),
('Cosmin','Tudor','cosmin.tudor@email.com','0783333333','2022-05-08',9500,25,'BI Developer'),
('Adrian','Ilie','adrian.ilie@email.com','0793333333','2018-01-16',9100,26,'Technical Support Engineer'),
('Laura','Matei','laura.matei@email.com','0714444444','2017-04-23',13200,27,'Product Manager'),
('Marius','Pop','marius.pop@email.com','0724444444','2023-03-11',8400,28,'Innovation Engineer'),
('Raluca','Nistor','raluca.nistor@email.com','0734444444','2021-12-02',9900,29,'QA Automation Engineer');
GO

SELECT COUNT(*)
FROM Employees;

INSERT INTO Timesheets
(
    EmployeeID,
    WeekStart,
    WeekEnd,
    Status,
    SubmittedDate,
    ApprovedDate
)
VALUES
(1,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(2,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(3,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(4,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(5,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(6,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(7,'2025-05-05','2025-05-11','Submitted','2025-05-12',NULL),
(8,'2025-05-05','2025-05-11','Submitted','2025-05-12',NULL),
(9,'2025-05-05','2025-05-11','Draft',NULL,NULL),
(10,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(11,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(12,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(13,'2025-05-05','2025-05-11','Submitted','2025-05-12',NULL),
(14,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(15,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(16,'2025-05-05','2025-05-11','Draft',NULL,NULL),
(17,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(18,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(19,'2025-05-05','2025-05-11','Submitted','2025-05-12',NULL),
(20,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(21,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(22,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(23,'2025-05-05','2025-05-11','Draft',NULL,NULL),
(24,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(25,'2025-05-05','2025-05-11','Submitted','2025-05-12',NULL),
(26,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(27,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(28,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13'),
(29,'2025-05-05','2025-05-11','Submitted','2025-05-12',NULL),
(30,'2025-05-05','2025-05-11','Approved','2025-05-12','2025-05-13');
GO


INSERT INTO Projects
(
    ProjectName,
    ClientID,
    StartDate,
    EndDate,
    Budget
)
VALUES
('Payroll System',1,'2024-01-01',NULL,180000),
('CRM Platform',2,'2024-01-15',NULL,250000),
('ERP Migration',3,'2024-02-01',NULL,320000),
('Cloud Infrastructure',4,'2024-02-10',NULL,410000),
('Online Banking',5,'2024-03-01',NULL,550000),
('Manufacturing Portal',6,'2024-03-10',NULL,290000),
('Insurance Platform',7,'2024-04-01',NULL,340000),
('Retail Analytics',8,'2024-04-15',NULL,260000),
('Fleet Management',9,'2024-05-01',NULL,310000),
('HR Management',10,'2024-05-15',NULL,170000),
('Customer Portal',11,'2024-06-01',NULL,215000),
('Inventory System',12,'2024-06-10',NULL,285000),
('Healthcare Dashboard',13,'2024-07-01',NULL,395000),
('Payment Gateway',14,'2024-07-15',NULL,620000),
('IoT Monitoring',15,'2024-08-01',NULL,455000),
('AI Assistant',16,'2024-08-15',NULL,700000),
('Business Intelligence',17,'2024-09-01',NULL,335000),
('Document Management',18,'2024-09-10',NULL,225000),
('Mobile Banking',19,'2024-10-01',NULL,640000),
('Warehouse Automation',20,'2024-10-15',NULL,480000),
('Data Warehouse',21,'2024-11-01',NULL,530000),
('Cloud Migration',22,'2024-11-10',NULL,360000),
('Smart Factory',23,'2024-12-01',NULL,490000),
('Identity Management',24,'2024-12-15',NULL,375000),
('Booking Platform',25,'2025-01-01',NULL,265000),
('E-Commerce Platform',26,'2025-01-10',NULL,445000),
('Security Operations',27,'2025-02-01',NULL,415000),
('Digital Twin',28,'2025-02-15',NULL,610000),
('Automation Hub',29,'2025-03-01',NULL,520000),
('Employee Portal',30,'2025-03-10',NULL,195000);
GO

INSERT INTO TimesheetEntries
(
    TimesheetID,
    ProjectID,
    CategoryID,
    LocationID,
    WorkDate,
    HoursWorked,
    WorkDescription,
    AdditionalInfo
)
VALUES
(1,1,1,1,'2025-05-05',4,'Payroll module development','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(1,1,3,1,'2025-05-06',2,'Unit testing','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(1,2,5,11,'2025-05-07',1,'Project meeting','{"device":"Laptop","browser":"Teams","workMode":"Remote"}'),
(1,2,2,11,'2025-05-08',3,'Bug fixing','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),

(2,2,1,2,'2025-05-05',5,'CRM backend','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(2,2,4,2,'2025-05-06',2,'Code review','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(2,3,6,11,'2025-05-07',1,'Research','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),
(2,3,2,11,'2025-05-08',2,'Bug fixing','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),

(3,3,3,3,'2025-05-05',4,'Regression testing','{"device":"Laptop","browser":"Firefox","workMode":"Office"}'),
(3,3,5,3,'2025-05-06',2,'Sprint meeting','{"device":"Laptop","browser":"Firefox","workMode":"Office"}'),
(3,4,2,11,'2025-05-07',1,'Issue validation','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),
(3,4,7,11,'2025-05-08',2,'Application support','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),

(4,4,9,4,'2025-05-05',4,'Deployment','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(4,4,18,4,'2025-05-06',2,'Environment monitoring','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(4,5,19,11,'2025-05-07',1,'Performance optimization','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),
(4,5,20,11,'2025-05-08',3,'Security review','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),

(5,5,22,5,'2025-05-05',3,'Requirement analysis','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(5,5,23,5,'2025-05-06',2,'Sprint planning','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(5,6,24,11,'2025-05-07',1,'Sprint retrospective','{"device":"Laptop","browser":"Teams","workMode":"Remote"}'),
(5,6,25,11,'2025-05-08',2,'Daily standup','{"device":"Laptop","browser":"Teams","workMode":"Remote"}'),

(6,6,11,6,'2025-05-05',5,'Application design','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(6,6,14,6,'2025-05-06',2,'Code refactoring','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(6,7,15,11,'2025-05-07',1,'Knowledge sharing','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),
(6,7,12,11,'2025-05-08',2,'Technical training','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),

(7,7,8,7,'2025-05-05',4,'Customer support','{"device":"Laptop","browser":"Firefox","workMode":"Office"}'),
(7,7,17,7,'2025-05-06',2,'Incident resolution','{"device":"Laptop","browser":"Firefox","workMode":"Office"}'),
(7,8,13,11,'2025-05-07',1,'System maintenance','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),
(7,8,10,11,'2025-05-08',2,'Project planning','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),

(8,8,21,8,'2025-05-05',4,'Data migration','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(8,8,28,8,'2025-05-06',2,'Proof of concept','{"device":"Laptop","browser":"Edge","workMode":"Office"}');
GO

SELECT COUNT(*) AS TotalProjects
FROM Projects;

SELECT ProjectID, ProjectName
FROM Projects
ORDER BY ProjectID;

SELECT COUNT(*) AS TotalProjects
FROM Projects;

SELECT COUNT(*) AS TotalEmployees
FROM Employees;

SELECT *
FROM Clients;
SELECT COUNT(*) AS TotalClients
FROM Clients;

INSERT INTO TimesheetEntries
(
    TimesheetID,
    ProjectID,
    CategoryID,
    LocationID,
    WorkDate,
    HoursWorked,
    WorkDescription,
    AdditionalInfo
)
VALUES
(8,9,9,8,'2025-05-07',3,'Deployment activities','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(8,9,18,8,'2025-05-08',2,'Infrastructure monitoring','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),

(9,9,1,9,'2025-05-05',4,'Feature implementation','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(9,9,4,9,'2025-05-06',2,'Code review','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(9,10,5,11,'2025-05-07',1,'Sprint meeting','{"device":"Laptop","browser":"Teams","workMode":"Remote"}'),
(9,10,2,11,'2025-05-08',3,'Bug fixing','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),

(10,10,11,10,'2025-05-05',5,'Solution design','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(10,10,14,10,'2025-05-06',2,'Code refactoring','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(10,11,15,11,'2025-05-07',1,'Knowledge sharing','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),
(10,11,12,11,'2025-05-08',2,'Technical training','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),

(11,11,3,16,'2025-05-05',4,'Functional testing','{"device":"Laptop","browser":"Firefox","workMode":"Client Site"}'),
(11,11,17,16,'2025-05-06',2,'Incident resolution','{"device":"Laptop","browser":"Firefox","workMode":"Client Site"}'),
(11,12,13,11,'2025-05-07',1,'System maintenance','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),
(11,12,10,11,'2025-05-08',2,'Planning session','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),

(12,12,21,17,'2025-05-05',4,'Data migration','{"device":"Laptop","browser":"Edge","workMode":"Client Site"}'),
(12,12,28,17,'2025-05-06',2,'Proof of concept','{"device":"Laptop","browser":"Edge","workMode":"Client Site"}'),
(12,13,20,11,'2025-05-07',1,'Security assessment','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),
(12,13,18,11,'2025-05-08',2,'Infrastructure monitoring','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),

(13,13,1,13,'2025-05-05',5,'Backend development','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(13,13,4,13,'2025-05-06',2,'Peer review','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(13,14,6,11,'2025-05-07',1,'Technical research','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),
(13,14,7,11,'2025-05-08',2,'Support activities','{"device":"Laptop","browser":"Edge","workMode":"Remote"}'),

(14,14,9,14,'2025-05-05',4,'Application deployment','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(14,14,19,14,'2025-05-06',2,'Performance optimization','{"device":"Laptop","browser":"Chrome","workMode":"Office"}'),
(14,15,23,11,'2025-05-07',1,'Sprint planning','{"device":"Laptop","browser":"Teams","workMode":"Remote"}'),
(14,15,24,11,'2025-05-08',2,'Sprint retrospective','{"device":"Laptop","browser":"Teams","workMode":"Remote"}'),

(15,15,11,15,'2025-05-05',4,'Architecture design','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(15,15,20,15,'2025-05-06',2,'Security review','{"device":"Laptop","browser":"Edge","workMode":"Office"}'),
(15,16,29,11,'2025-05-07',1,'Environment setup','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}'),
(15,16,30,11,'2025-05-08',2,'Release management','{"device":"Laptop","browser":"Chrome","workMode":"Remote"}');
GO

INSERT INTO LeaveRequests
(
    EmployeeID,
    StartDate,
    EndDate,
    LeaveType,
    Status,
    Reason
)
VALUES
(1,'2025-06-02','2025-06-06','Annual Leave','Approved','Summer vacation'),
(2,'2025-06-09','2025-06-10','Medical Leave','Approved','Medical consultation'),
(3,'2025-06-16','2025-06-20','Annual Leave','Pending','Family vacation'),
(4,'2025-06-23','2025-06-24','Personal Leave','Approved','Personal matters'),
(5,'2025-07-01','2025-07-05','Annual Leave','Approved','Holiday'),
(6,'2025-07-07','2025-07-08','Medical Leave','Approved','Medical appointment'),
(7,'2025-07-14','2025-07-18','Annual Leave','Pending','Travel'),
(8,'2025-07-21','2025-07-22','Personal Leave','Rejected','Insufficient coverage'),
(9,'2025-08-04','2025-08-08','Annual Leave','Approved','Vacation'),
(10,'2025-08-11','2025-08-12','Medical Leave','Approved','Recovery'),
(11,'2025-08-18','2025-08-22','Annual Leave','Approved','Family trip'),
(12,'2025-08-25','2025-08-26','Personal Leave','Pending','Personal event'),
(13,'2025-09-01','2025-09-05','Annual Leave','Approved','Holiday'),
(14,'2025-09-08','2025-09-09','Medical Leave','Approved','Dental appointment'),
(15,'2025-09-15','2025-09-19','Annual Leave','Approved','Vacation'),
(16,'2025-09-22','2025-09-23','Personal Leave','Approved','Administrative tasks'),
(17,'2025-10-06','2025-10-10','Annual Leave','Pending','Family vacation'),
(18,'2025-10-13','2025-10-14','Medical Leave','Approved','Medical examination'),
(19,'2025-10-20','2025-10-24','Annual Leave','Approved','Travel'),
(20,'2025-10-27','2025-10-28','Personal Leave','Approved','Personal reasons'),
(21,'2025-11-03','2025-11-07','Annual Leave','Approved','Holiday'),
(22,'2025-11-10','2025-11-11','Medical Leave','Approved','Check-up'),
(23,'2025-11-17','2025-11-21','Annual Leave','Pending','Vacation'),
(24,'2025-11-24','2025-11-25','Personal Leave','Approved','Family event'),
(25,'2025-12-01','2025-12-05','Annual Leave','Approved','Vacation'),
(26,'2025-12-08','2025-12-09','Medical Leave','Approved','Medical leave'),
(27,'2025-12-15','2025-12-19','Annual Leave','Approved','Holiday'),
(28,'2025-12-22','2025-12-23','Personal Leave','Pending','Personal matters'),
(29,'2026-01-05','2026-01-09','Annual Leave','Approved','Winter holiday'),
(30,'2026-01-12','2026-01-13','Medical Leave','Approved','Medical consultation');
GO

INSERT INTO AuditLogs
(
    EmployeeID,
    ActionName,
    IPAddress,
    Details
)
VALUES
(1,'Login','192.168.1.10','{"action":"login","status":"success"}'),
(2,'Create Timesheet','192.168.1.11','{"timesheet":"created"}'),
(3,'Update Timesheet','192.168.1.12','{"field":"hours"}'),
(4,'Approve Timesheet','192.168.1.13','{"status":"approved"}'),
(5,'Login','192.168.1.14','{"action":"login"}'),
(6,'Logout','192.168.1.15','{"action":"logout"}'),
(7,'Create Leave Request','192.168.1.16','{"leave":"annual"}'),
(8,'Reject Leave','192.168.1.17','{"status":"rejected"}'),
(9,'Password Change','192.168.1.18','{"security":"password"}'),
(10,'Profile Update','192.168.1.19','{"profile":"updated"}'),
(11,'Login','192.168.1.20','{"action":"login"}'),
(12,'Submit Timesheet','192.168.1.21','{"status":"submitted"}'),
(13,'Approve Timesheet','192.168.1.22','{"status":"approved"}'),
(14,'Logout','192.168.1.23','{"action":"logout"}'),
(15,'Login','192.168.1.24','{"action":"login"}'),
(16,'Update Timesheet','192.168.1.25','{"hours":"modified"}'),
(17,'Create Timesheet','192.168.1.26','{"timesheet":"created"}'),
(18,'Delete Draft','192.168.1.27','{"draft":"deleted"}'),
(19,'Login','192.168.1.28','{"action":"login"}'),
(20,'Submit Leave','192.168.1.29','{"leave":"submitted"}'),
(21,'Approve Leave','192.168.1.30','{"leave":"approved"}'),
(22,'Reject Leave','192.168.1.31','{"leave":"rejected"}'),
(23,'Login','192.168.1.32','{"action":"login"}'),
(24,'Logout','192.168.1.33','{"action":"logout"}'),
(25,'Export Report','192.168.1.34','{"report":"monthly"}'),
(26,'Login','192.168.1.35','{"action":"login"}'),
(27,'Update Profile','192.168.1.36','{"profile":"updated"}'),
(28,'Reset Password','192.168.1.37','{"security":"reset"}'),
(29,'Create Timesheet','192.168.1.38','{"timesheet":"created"}'),
(30,'Approve Timesheet','192.168.1.39','{"status":"approved"}');
GO

/*INDEXES*/

/*used to improve employee searches by last name*/
CREATE INDEX IX_Employees_LastName
ON Employees(LastName);
GO

/*used to improve project searches by project name*/
CREATE INDEX IX_Projects_ProjectName
ON Projects(ProjectName);
GO


/*used for filtering work entries by work date*/
CREATE INDEX IX_TimesheetEntries_WorkDate
ON TimesheetEntries(WorkDate);
GO


/*used for filtering leave requests by status*/
CREATE INDEX IX_LeaveRequests_Status
ON LeaveRequests(Status);
GO


/*VIEW*/

/*total number of worked hours for each employee and project*/
CREATE VIEW dbo.vw_EmployeeProjectHours
AS
SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    p.ProjectName,
    SUM(te.HoursWorked) AS TotalHours
FROM Employees AS e
INNER JOIN Timesheets AS t
    ON e.EmployeeID = t.EmployeeID
INNER JOIN TimesheetEntries AS te
    ON t.TimesheetID = te.TimesheetID
INNER JOIN Projects AS p
    ON te.ProjectID = p.ProjectID
GROUP BY
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    p.ProjectName;
GO

SELECT *
FROM dbo.vw_EmployeeProjectHours;


/*INDEXED VIEW*/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

SET ANSI_PADDING ON;
GO

SET ANSI_WARNINGS ON;
GO

SET CONCAT_NULL_YIELDS_NULL ON;
GO

SET ARITHABORT ON;
GO

SET NUMERIC_ROUNDABORT OFF;
GO

CREATE VIEW dbo.vw_ProjectSummary
WITH SCHEMABINDING
AS

SELECT
    p.ProjectID,
    COUNT_BIG(*) AS TotalEntries,
    SUM(CAST(te.HoursWorked AS DECIMAL(10,2))) AS TotalHours
FROM dbo.Projects p
INNER JOIN dbo.TimesheetEntries te
ON p.ProjectID = te.ProjectID
GROUP BY
    p.ProjectID;
GO

CREATE UNIQUE CLUSTERED INDEX IX_vw_ProjectSummary
ON dbo.vw_ProjectSummary(ProjectID);
GO

/*GROUP BY
Returns the total worked hours
for every employee.
*/

SELECT e.FirstName, e.LastName, SUM(te.HoursWorked) AS TotalHours
FROM Employees e
INNER JOIN Timesheets t
ON e.EmployeeID=t.EmployeeID
INNER JOIN TimesheetEntries te
ON t.TimesheetID=te.TimesheetID
GROUP BY e.FirstName, e.LastName
ORDER BY TotalHours DESC;


/*
Returns all employees including
those without submitted timesheets.
*/

SELECT e.EmployeeID, e.FirstName, e.LastName, t.TimesheetID, t.Status
FROM Employees e
LEFT JOIN Timesheets t
ON e.EmployeeID=t.EmployeeID
ORDER BY e.EmployeeID;


/*
Ranks employees by total worked hours.
Employees with the same number of hours
receive the same rank.
*/

SELECT e.EmployeeID, e.FirstName, e.LastName, SUM(te.HoursWorked) AS TotalHours, DENSE_RANK()

    OVER

    (
        ORDER BY SUM(te.HoursWorked) DESC
    )

AS EmployeeRank
FROM Employees e
INNER JOIN Timesheets t
ON e.EmployeeID=t.EmployeeID
INNER JOIN TimesheetEntries te
ON t.TimesheetID=te.TimesheetID
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

/*
 JSON.
*/

SELECT EntryID,
    JSON_VALUE(AdditionalInfo,'$.workMode') AS WorkMode,
    JSON_VALUE(AdditionalInfo,'$.browser') AS Browser,
    JSON_VALUE(AdditionalInfo,'$.device') AS Device
FROM TimesheetEntries;

/*STORED PROCEDURE*/

CREATE PROCEDURE usp_GetEmployeeHours
(
    @EmployeeID INT
)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT e.FirstName, e.LastName, SUM(te.HoursWorked) AS TotalHours
    FROM Employees e
    INNER JOIN Timesheets t
    ON e.EmployeeID=t.EmployeeID
    INNER JOIN TimesheetEntries te
    ON t.TimesheetID=te.TimesheetID
    WHERE e.EmployeeID=@EmployeeID
    GROUP BY e.FirstName, e.LastName;
END;
GO
EXEC usp_GetEmployeeHours @EmployeeID = 5;

/*TRIGGER

This trigger is automatically executed after a new timesheet is inserted. 
It creates an audit record in the AuditLogs table, 
storing the employee, action, IP address, and additional information in JSON format.*/


CREATE TRIGGER trg_AuditTimesheetInsert
ON Timesheets
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditLogs
    (
        EmployeeID,
        ActionName,
        IPAddress,
        Details
    )
    SELECT
        EmployeeID,
        'Timesheet Created',
        '127.0.0.1',
        '{"action":"automatic insert"}'
    FROM inserted;
END;
GO

SELECT COUNT(*) AS TotalAuditLogs
FROM AuditLogs;

INSERT INTO Timesheets
(
    EmployeeID,
    WeekStart,
    WeekEnd,
    Status
)
VALUES
(
    5,
    '2025-06-02',
    '2025-06-08',
    'Draft'
);
GO

SELECT TOP (5)
       LogID,
       EmployeeID,
       ActionName,
       ActionDate,
       IPAddress,
       Details
FROM AuditLogs
ORDER BY LogID DESC;

