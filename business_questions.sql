-- analysis/business_questions.sql
-- Run these after loading data & creating the view (optional).

-- 1) LOS vs readmission
WITH b AS (
  SELECT los_bucket, is_readmit30 FROM public.cleaned_diabetic
)
SELECT los_bucket, COUNT(*) AS n, ROUND(100.0*AVG(is_readmit30),2) AS r30_pct
FROM b GROUP BY 1 ORDER BY 1;

-- 2) Medication change effect
SELECT change, COUNT(*) AS n, ROUND(100.0*AVG((readmitted='<30')::int),2) AS r30_pct
FROM public.diabetic
WHERE change IS NOT NULL AND change <> '?'
GROUP BY change ORDER BY r30_pct DESC, n DESC;

-- 3) Prior inpatient history
SELECT
  CASE
    WHEN number_inpatient >= 2 THEN '>=2 prior'
    WHEN number_inpatient = 1  THEN '1 prior'
    ELSE '0 prior'
  END AS prior_inpatient_band,
  COUNT(*) AS n,
  ROUND(100.0*AVG((readmitted='<30')::int),2) AS r30_pct
FROM public.diabetic
GROUP BY 1 ORDER BY 1;

-- 4) Med categories (insulin vs metformin)
WITH c AS (
  SELECT
    CASE WHEN insulin <> 'No'    AND insulin IS NOT NULL   THEN 1 ELSE 0 END AS on_insulin,
    CASE WHEN metformin <> 'No'  AND metformin IS NOT NULL THEN 1 ELSE 0 END AS on_metformin,
    (readmitted = '<30')::int AS is_r30
  FROM public.diabetic
)
SELECT
  CASE
    WHEN on_insulin=1 AND on_metformin=1 THEN 'Both'
    WHEN on_insulin=1 AND on_metformin=0 THEN 'Insulin only'
    WHEN on_insulin=0 AND on_metformin=1 THEN 'Metformin only'
    ELSE 'Neither'
  END AS med_group,
  COUNT(*) AS n, ROUND(100.0*AVG(is_r30),2) AS r30_pct
FROM c GROUP BY 1 ORDER BY r30_pct DESC, n DESC;

-- 5) Polypharmacy deciles
WITH b AS (
  SELECT num_medications AS meds, (readmitted='<30')::int AS is_r30
  FROM public.diabetic WHERE num_medications IS NOT NULL
),
d AS (SELECT NTILE(10) OVER (ORDER BY meds) AS meds_decile, is_r30 FROM b)
SELECT meds_decile, COUNT(*) AS n, ROUND(100.0*AVG(is_r30),2) AS r30_pct
FROM d GROUP BY 1 ORDER BY 1;

-- 6) Average labs overall, by specialty, by diag group
SELECT ROUND(AVG(num_lab_procedures),2) AS avg_labs_overall FROM public.diabetic;

SELECT COALESCE(medical_specialty,'Unknown') AS specialty,
       COUNT(*) AS n, ROUND(AVG(num_lab_procedures),2) AS avg_labs
FROM public.diabetic
GROUP BY 1 HAVING COUNT(*)>=50 ORDER BY avg_labs DESC;

WITH labeled AS (
  SELECT
    CASE
      WHEN diag_1 IS NULL THEN 'Unknown'
      WHEN diag_1 ~ '^[V]' THEN 'Supplementary (V)'
      WHEN diag_1 ~ '^[E]' THEN 'External (E)'
      WHEN diag_1::float BETWEEN 001 AND 139 THEN 'Infectious'
      WHEN diag_1::float BETWEEN 140 AND 239 THEN 'Neoplasms'
      WHEN diag_1::float BETWEEN 240 AND 279 THEN 'Endocrine/Metabolic'
      WHEN diag_1::float BETWEEN 280 AND 289 THEN 'Blood'
      WHEN diag_1::float BETWEEN 290 AND 319 THEN 'Mental'
      WHEN diag_1::float BETWEEN 320 AND 389 THEN 'Nervous'
      WHEN diag_1::float BETWEEN 390 AND 459 THEN 'Circulatory'
      WHEN diag_1::float BETWEEN 460 AND 519 THEN 'Respiratory'
      WHEN diag_1::float BETWEEN 520 AND 579 THEN 'Digestive'
      WHEN diag_1::float BETWEEN 580 AND 629 THEN 'Genitourinary'
      WHEN diag_1::float BETWEEN 630 AND 679 THEN 'Pregnancy'
      WHEN diag_1::float BETWEEN 680 AND 709 THEN 'Skin'
      WHEN diag_1::float BETWEEN 710 AND 739 THEN 'Musculoskeletal'
      WHEN diag_1::float BETWEEN 740 AND 759 THEN 'Congenital'
      WHEN diag_1::float BETWEEN 760 AND 779 THEN 'Perinatal'
      WHEN diag_1::float BETWEEN 780 AND 799 THEN 'Symptoms/Signs'
      WHEN diag_1::float BETWEEN 800 AND 999 THEN 'Injury/Poisoning'
      ELSE 'Other'
    END AS diag_1_group,
    num_lab_procedures AS labs
  FROM public.diabetic
)
SELECT diag_1_group, COUNT(*) AS n, ROUND(AVG(labs),2) AS avg_labs
FROM labeled GROUP BY 1 HAVING COUNT(*)>=100 ORDER BY avg_labs DESC;

-- 7) A1C outcome
SELECT
  CASE
    WHEN A1Cresult IN ('>7','>8') THEN 'Abnormal'
    WHEN A1Cresult = 'Norm'       THEN 'Normal'
    WHEN A1Cresult = 'None'       THEN 'Not measured'
    ELSE 'Other/Unknown'
  END AS a1c_group,
  COUNT(*) AS n,
  ROUND(100.0*AVG((readmitted='<30')::int),2) AS r30_pct
FROM public.diabetic
GROUP BY 1 ORDER BY r30_pct DESC, n DESC;

-- 8) Avg LOS by specialty
SELECT COALESCE(medical_specialty,'Unknown') AS specialty,
       COUNT(*) AS n,
       ROUND(AVG(time_in_hospital),2) AS avg_los
FROM public.diabetic
GROUP BY 1 HAVING COUNT(*)>=50 ORDER BY avg_los DESC, n DESC;

-- 9) Discharge disposition vs readmit
SELECT discharge_disposition_id AS disposition,
       COUNT(*) AS n,
       ROUND(100.0*AVG((readmitted='<30')::int),2) AS r30_pct,
       ROUND(AVG(time_in_hospital),2) AS avg_los
FROM public.diabetic
GROUP BY 1 HAVING COUNT(*)>=200 ORDER BY r30_pct DESC, n DESC;

-- 10) Admission sources among high utilizers
WITH high AS (SELECT * FROM public.diabetic WHERE number_inpatient >= 2)
SELECT admission_source_id AS admit_source,
       COUNT(*) AS n,
       ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),2) AS pct_of_high_utilizers
FROM high GROUP BY 1 ORDER BY n DESC;

-- 11) Hospitals (not present in dataset) — placeholder.

-- 12) Race disparities
SELECT COALESCE(race,'Unknown') AS race, COUNT(*) AS n,
       ROUND(100.0*AVG((readmitted='<30')::int),2) AS r30_pct
FROM public.diabetic
GROUP BY 1 HAVING COUNT(*)>=50 ORDER BY r30_pct DESC, n DESC;

-- 13) Gender disparities
SELECT COALESCE(gender,'Unknown') AS gender, COUNT(*) AS n,
       ROUND(100.0*AVG((readmitted='<30')::int),2) AS r30_pct
FROM public.diabetic
GROUP BY 1 HAVING COUNT(*)>=50 ORDER BY r30_pct DESC, n DESC;

-- 14) 70+ vs 30–40: meds & labs
WITH bands AS (
  SELECT
    CASE
      WHEN age IN ('[70-80)','[80-90)','[90-100)') THEN '70+'
      WHEN age = '[30-40)' THEN '30-40'
      ELSE 'Other'
    END AS age_band,
    num_medications AS meds, num_lab_procedures AS labs
  FROM public.diabetic
)
SELECT age_band, COUNT(*) AS n,
       ROUND(AVG(meds),2) AS avg_meds,
       ROUND(AVG(labs),2) AS avg_labs
FROM bands WHERE age_band IN ('70+','30-40')
GROUP BY 1 ORDER BY age_band;

-- 15) Monthly KPIs (synthetic month from encounter_id)
WITH base AS (
  SELECT
    date_trunc('month', to_date('2000-01-01','YYYY-MM-DD') + (encounter_id % 365)) AS month_key,
    time_in_hospital AS los, num_medications AS meds, num_lab_procedures AS labs,
    (readmitted = '<30')::int AS is_r30
  FROM public.diabetic
)
SELECT month_key::date AS month, COUNT(*) AS admissions,
       ROUND(AVG(los),2) AS avg_los,
       ROUND(AVG(meds),2) AS avg_meds,
       ROUND(AVG(labs),2) AS avg_labs,
       ROUND(100.0*AVG(is_r30),2) AS readmit30_pct
FROM base GROUP BY 1 ORDER BY 1;
