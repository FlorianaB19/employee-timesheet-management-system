# 🚀 Employee Timesheet Management System

A relational database project developed using **Microsoft SQL Server** that simulates a real-world employee timesheet management system.

The application manages employees, departments, projects, work entries, leave requests and audit logs while demonstrating advanced SQL Server features such as JSON support, indexed views, triggers and stored procedures.

---

# 📋 Project Overview

The purpose of this project is to design and implement a normalized relational database capable of managing employee timesheets.

The implementation includes:

- Employee management
- Project management
- Timesheet management
- Leave management
- Audit logging
- JSON data storage
- Database automation using triggers
- Stored procedures
- Analytical SQL queries

---

# 🏗 Database Architecture

The database contains the following entities:

| Table | Description |
|--------|-------------|
| Departments | Company departments |
| Employees | Employee information |
| Clients | External clients |
| Projects | Company projects |
| TaskCategories | Types of work activities |
| WorkLocations | Office and remote locations |
| Timesheets | Weekly employee timesheets |
| TimesheetEntries | Individual work entries |
| LeaveRequests | Employee leave requests |
| AuditLogs | Audit trail generated automatically |

---

# 📊 Entity Relationship Diagram

> Add the database diagram here after exporting it from SQL Server Management Studio.

```text
README
└── diagrams
        database_diagram.png
```



# ⚙ Technologies

- Microsoft SQL Server 2022
- SQL Server Management Studio (SSMS)
- Docker
- Rancher Desktop
- Git
- GitHub

---

# 📂 Project Structure

```text
employee-timesheet-management-system
│
├── README.md
│
├── sql
│   └── TimesheetDB.sql
│
├── diagrams
│   └── database_diagram.png

```

---

# 📈 Database Features

## Constraints

- Primary Keys
- Foreign Keys
- UNIQUE
- CHECK
- DEFAULT
- NOT NULL

---

## JSON Support

The project stores semistructured data using JSON.

Tables containing JSON:

- TimesheetEntries
- AuditLogs

Example:

```json
{
    "device":"Laptop",
    "browser":"Chrome",
    "workMode":"Remote"
}
```

---

## Indexes

Additional indexes were created to improve query performance.

Examples:

- Employee Last Name
- Project Name
- Work Date
- Leave Status

---

## Views

### Employee Worked Hours

Displays the total worked hours for every employee.

---

## Indexed View

Aggregates worked hours for each project.

Used as the SQL Server equivalent of a Materialized View.

---

## Stored Procedure

Returns the total worked hours for a selected employee.

Example:

```sql
EXEC usp_GetEmployeeHours @EmployeeID = 5;
```

---

## Trigger

A trigger automatically inserts a record into the AuditLogs table whenever a new Timesheet is created.

This demonstrates database-level automation and audit tracking.

---

# 📊 SQL Queries

The project includes examples of:

- GROUP BY
- LEFT JOIN
- INNER JOIN
- Aggregate Functions
- Window Functions
- DENSE_RANK()
- JSON_VALUE()

---

# ▶ Running the Project

1. Open SQL Server Management Studio.
2. Connect to your SQL Server instance.
3. Execute:

```text
sql/TimesheetDB.sql
```

The script automatically:

- creates the database
- creates all tables
- creates constraints
- inserts sample data
- creates indexes
- creates views
- creates stored procedures
- creates triggers

---


# 🎯 Learning Objectives

This project demonstrates practical knowledge of:

- Relational Database Design
- SQL Server
- Database Normalization
- Data Integrity
- Query Optimization
- Database Programming
- JSON Processing
- Window Functions
- Trigger Programming

---

# 👩‍💻 Author

**Floriana Berbecel**

GitHub:

https://github.com/FlorianaB19
