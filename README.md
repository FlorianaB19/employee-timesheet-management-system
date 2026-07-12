# Employee Timesheet Management System

## Overview

This project implements an Employee Timesheet Management System using Microsoft SQL Server.

The database was designed to simulate a real-world timesheet application used to manage employees, projects and worked hours.

---

## Features

- Relational database design
- Primary Keys
- Foreign Keys
- UNIQUE Constraints
- CHECK Constraints
- DEFAULT Constraints
- JSON data support
- Additional indexes
- SQL Views
- Indexed View (Materialized View equivalent)
- GROUP BY queries
- LEFT JOIN queries
- Window Functions (DENSE_RANK)
- Stored Procedure
- Trigger
- Sample data

---

## Database Entities

The project contains the following tables:

- Departments
- Employees
- Clients
- Projects
- TaskCategories
- WorkLocations
- Timesheets
- TimesheetEntries
- LeaveRequests
- AuditLogs

---

## Technologies

- Microsoft SQL Server 2022
- SQL Server Management Studio (SSMS)
- Docker
- Rancher Desktop
- Git
- GitHub

---

## Project Structure

```text
employee-timesheet-management-system
│
├── README.md
├── sql
│   └── TimesheetDB.sql
│
└── diagrams
```

---

## Main Database Objects

### Tables

10 relational tables with integrity constraints.

### View

Employee worked hours summary.

### Indexed View

Project worked hours aggregation.

### Stored Procedure

Returns the total worked hours for a selected employee.

### Trigger

Automatically inserts an audit record whenever a new timesheet is created.

---

## JSON Support

The project stores semistructured information using JSON inside the following tables:

- TimesheetEntries
- AuditLogs

---

## Author

Floriana Berbecel
