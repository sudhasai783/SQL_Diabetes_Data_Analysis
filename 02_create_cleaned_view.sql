-- 02_create_cleaned_view.sql
DROP VIEW IF EXISTS public.cleaned_diabetic;

CREATE VIEW public.cleaned_diabetic AS
WITH base AS (
  SELECT
    encounter_id, patient_nbr,
    NULLIF(race, '?')   AS race,
    NULLIF(gender, '?') AS gender,
    REPLACE(REPLACE(age, '[',''),')','') AS age_range,
    CASE WHEN weight='?' THEN NULL ELSE weight END AS weight_bucket,
    NULLIF(payer_code,'?') AS payer_code,
    NULLIF(medical_specialty,'?') AS medical_specialty,
    time_in_hospital, num_lab_procedures, num_procedures, num_medications,
    number_outpatient, number_emergency, number_inpatient, number_diagnoses,
    CASE WHEN diag_1 IN ('?','999') THEN NULL ELSE diag_1 END AS diag_1,
    CASE WHEN diag_2 IN ('?','999') THEN NULL ELSE diag_2 END AS diag_2,
    CASE WHEN diag_3 IN ('?','999') THEN NULL ELSE diag_3 END AS diag_3,
    max_glu_serum, A1Cresult,
    metformin, repaglinide, nateglinide, chlorpropamide, glimepiride, acetohexamide,
    glipizide, glyburide, tolbutamide, pioglitazone, rosiglitazone, acarbose,
    miglitol, troglitazone, tolazamide, examide, citoglipton,
    insulin, "glyburide-metformin", "glipizide-metformin",
    "glimepiride-pioglitazone", "metformin-rosiglitazone", "metformin-pioglitazone",
    change, diabetesMed, readmitted
  FROM public.diabetic
)
SELECT
  b.*,
  -- Convenient booleans/buckets
  (readmitted = '<30')::int AS is_readmit30,
  CASE
    WHEN time_in_hospital BETWEEN 1 AND 3  THEN '01–03'
    WHEN time_in_hospital BETWEEN 4 AND 6  THEN '04–06'
    WHEN time_in_hospital BETWEEN 7 AND 10 THEN '07–10'
    WHEN time_in_hospital >= 11            THEN '11+'
    ELSE 'Unknown'
  END AS los_bucket,
  CASE WHEN num_medications > 10 THEN 1 ELSE 0 END AS is_polypharmacy,
  -- ICD-9 chapter rollup for diag_1
  CASE
    WHEN diag_1 IS NULL THEN 'Unknown'
    WHEN diag_1 ~ '^[V]' THEN 'Supplementary (V)'
    WHEN diag_1 ~ '^[E]' THEN 'External (E)'
    WHEN (diag_1 ~ '^[0-9]') THEN
      CASE
        WHEN diag_1::float BETWEEN 001 AND 139 THEN 'Infectious'
        WHEN diag_1::float BETWEEN 140 AND 239 THEN 'Neoplasms'
        WHEN diag_1::float BETWEEN 240 AND 279 THEN 'Endocrine/Metabolic'
        WHEN diag_1::float BETWEEN 280 AND 289 THEN 'Blood'
        WHEN diag_1::float BETWEEN 290 AND 319 THEN 'Mental'
        WHEN diag_1::float BETWEEN 320 AND 389 THEN 'Nervous system'
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
      END
    ELSE 'Other'
  END AS diag_1_group
FROM base b;
