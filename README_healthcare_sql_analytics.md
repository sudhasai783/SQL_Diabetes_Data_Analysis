
<div align="center">

# 🏥📊 Healthcare SQL Analytics  
### **Readmission Risk — Diabetes 130-US Hospitals**

<img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-17-blue?logo=postgresql&logoColor=white">
<img alt="Made with SQL" src="https://img.shields.io/badge/Made%20with-SQL-2ea44f">
<img alt="pgAdmin" src="https://img.shields.io/badge/pgAdmin-4-FF6F00?logo=postgresql&logoColor=white">
<img alt="Status" src="https://img.shields.io/badge/Focus-Readmissions-success">
<br>
</div>

## 🚀 What this is
I built a **SQL-first** analysis of 30-day readmissions using the **Diabetes 130-US hospitals** dataset. The goal: **answer realistic hospital questions with pure SQL** (PostgreSQL + pgAdmin) — from **length-of-stay** to **medication effects** and **equity**.

---

## 🧭 Table of Contents
- [Why I did this](#-why-i-did-this)
- [Repo structure](#-repo-structure)
- [How I run it](#-how-i-run-it)
- [Business questions I answer](#-business-questions-i-answer)
- [SQL highlights](#-sql-highlights)
- [Results (to fill in)](#-results-to-fill-in)
- [Screenshots / assets](#-screenshots--assets)
- [Notes & caveats](#-notes--caveats)

---

## 🎯 Why I did this
- Practice **production-style SQL**: staging → typed table → cleaned view.  
- Show how I turn a messy healthcare CSV (with `?` and ICD-9 codes) into **analysis-ready** tables.  
- Answer **operational** and **clinical** questions quality teams actually ask.

---

## 🗂️ Repo structure
```
.
├── 00_create_staging.sql            # TEXT-only staging table (safe import)
├── 01_create_typed_and_insert.sql   # Typed table + cleaning INSERT
├── 02_create_cleaned_view.sql       # Analysis view (LOS buckets, flags, ICD groups)
├── business_questions.sql           # All analytics queries
├── diabetic_data.csv                # Source CSV (Kaggle) - added here for convenience
└── README.md
```

> **Tip:** In a real project I’d usually keep raw data out of Git with a `.gitignore`. I included the CSV here for easy repro.

---

## ⚙️ How I run it
**Environment:** PostgreSQL 17 + pgAdmin 4

**1) Create staging (import-proof)**  
Run `00_create_staging.sql` → creates `public.diabetic_stg` (all `TEXT`).

**2) Import CSV via pgAdmin**  
Right-click `public.diabetic_stg` → **Import/Export…**  
- Format **CSV**, Header **Yes**, Delimiter `,`, Quote `"`  
- **Null string** = `?` (turns `?` into actual `NULL`)  
- Method **COPY**

**3) Create typed table + insert cleaned data**  
Run `01_create_typed_and_insert.sql` → builds `public.diabetic` (typed), inserts from staging.  
- Handles `?`/`999` → `NULL`  
- Keeps `diag_1/2/3` as **VARCHAR** (ICD-9 can be `V`/`E`/decimals).  
- Widens text columns (e.g., `gender` may be `Unknown/Invalid`).

**4) Create analysis view**  
Run `02_create_cleaned_view.sql` → `public.cleaned_diabetic` with:  
- **`los_bucket`** (`01–03`, `04–06`, `07–10`, `11+`)  
- **`is_readmit30`** flag  
- **`is_polypharmacy`** flag  
- **ICD-9 chapter rollup** for `diag_1`

**5) Run analyses**  
Execute `business_questions.sql` (sections are labeled).

---

## 💼 Business questions I answer
1. **Do longer LOS lead to higher 30-day readmission risk?**  
2. **Medication changes** (`change='Ch'`) vs `No`: impact on readmissions?  
3. Do **prior inpatient admissions** (`number_inpatient`) predict readmission?  
4. Which **medication categories** (Insulin / Metformin / Both / Neither) have the highest readmits?  
5. **Polypharmacy:** how does `num_medications` relate to readmission probability?  
6. What’s the **average number of lab procedures** overall, by **specialty**, and by **diagnosis group**?  
7. Are **abnormal A1C** results associated with higher readmissions than normal?  
8. Average **LOS by medical specialty** — who has the longest stays?  
9. Which **discharge dispositions** have the highest 30-day readmissions?  
10. Which **admission sources** are most common among **high utilizers** (≥2 prior inpatient)?  
11. *(If available)* Which **hospitals** have the highest/lowest readmissions?  
12. **Race** differences in readmission rates.  
13. **Gender** differences in readmission rates.  
14. Do **70+** patients receive more **meds/labs** than **30–40**?  
15. **Monthly KPI pack** (admissions, ALOS, labs, meds, readmit%) using a synthetic month key.

---

## 🧠 SQL highlights
- **Staging → Typed → View** pipeline to separate concerns.  
- **Robust cleaning** of placeholders (`?`, `999`) and categorical fields.  
- **ICD-9 rollups** into business-readable **chapters** for `diag_1`.  
- **Bucketing & flags:** LOS buckets, polypharmacy, readmit-30.  
- **Stat indicators:** sample size thresholds (`HAVING COUNT(*) …`) and **correlation** checks.  
- **Pure SQL**, no ORM or notebook required.

---

## 📈 Results (to fill in with your numbers)
> I keep this section short and punchy with **%** and **N**.

- **LOS vs readmit:** `01–03: __% (N=__)`, `04–06: __%`, `07–10: __%`, `11+: __%` → **trend:** ↑ with LOS.  
- **Medication change (`Ch`) vs `No`:** `Ch: __% (N=__)` vs `No: __% (N=__)`.  
- **Prior inpatient (≥2):** `__% (N=__)` vs others `__%`.  
- **A1C (Abnormal vs Normal):** `Abnormal: __%` vs `Normal: __%`.  
- **Equity:** highest group by **race/gender** = `__% (N=__)` — interpret carefully.  
- **Ops:** top **discharge dispositions** by readmit% = `[#__, #__, #__]`.

> **One-liner takeaway:** *Target follow-ups for patients with **LOS ≥ 7**, **abnormal A1C**, and **≥2 prior inpatient visits**; watch high-risk discharge dispositions.*

---

## 🖼️ Screenshots / assets
Add images to an `assets/` folder and reference them here:

```md
![ERD](assets/erd.png)

**Readmission rate by LOS bucket**
![LOS vs Readmit](assets/los_readmit_rate.png)

**A1C result vs 30-day readmissions**
![A1C vs Readmit](assets/a1c_readmit_rate.png)
```

**Suggested visuals**
- `erd.png` — simple pipeline: `diabetic_stg → diabetic → cleaned_diabetic`  
- `los_readmit_rate.png` — bars by `los_bucket`  
- `a1c_readmit_rate.png` — bars by A1C group  
- `med_group_readmit.png` — Insulin / Metformin / Both / Neither  
- `polypharmacy_deciles.png` — deciles of `num_medications` vs readmit%

---

## 📝 Notes & caveats
- **ICD-9 codes** include `V`/`E` and decimals → keep as **VARCHAR**.  
- The dataset **does not** include real dates or hospital IDs (I call out where it matters).  
- Data is **de-identified**; this project is **educational** and not clinical advice.
