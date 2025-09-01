# 🩺 SQL Diabetes Data Analysis — Healthcare Analytics

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![ETL](https://img.shields.io/badge/ETL-Staging%20%E2%86%92%20Typed%20%E2%86%92%20Views-brightgreen)
![Domain](https://img.shields.io/badge/Domain-Healthcare-purple)
![Status](https://img.shields.io/badge/Project-Active-success)

> A compact, end-to-end **SQL project** where I ingest, clean, and analyze a diabetes hospitalization dataset to answer real business questions about **readmissions, length of stay (LOS), medications, and utilization**. The repo includes reproducible SQL scripts, a clean view, and question-driven analytics.

---

## 🧭 Table of Contents
- [Overview](#-overview)
- [Repository Structure](#-repository-structure)
- [Dataset](#-dataset)
- [Quick Start (PostgreSQL)](#-quick-start-postgresql)
- [Key Business Questions](#-key-business-questions)
- [Example Queries](#-example-queries)
- [Results & Notes](#-results--notes)
- [Troubleshooting](#-troubleshooting)
- [Assets & How to Present](#-assets--how-to-present)
- [License & Attribution](#-license--attribution)

---

## ✨ Overview
This project demonstrates practical **data engineering + analytics** in SQL:
- Create a **staging layer** from a raw CSV.
- Build a **typed table** with proper data types & constraints.
- Expose a **cleaned analytic view** used to answer stakeholder questions.
- Explore **readmission risk** signals (e.g., **LOS**, **medication changes**, **prior inpatient visits**, **number of meds**).
- Provide **reusable queries** for dashboards or notebooks.

Tech I used: **PostgreSQL (recommended)**, SQL window functions, aggregates, and lightweight data quality checks. Power BI/Tableau can be layered on top of the clean view for viz.

