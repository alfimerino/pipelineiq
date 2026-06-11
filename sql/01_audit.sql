-- SQLBook: Code
-- PQI-02: Data Audit
-- Purpose: Discover all data quality issues before cleaning
-- Tables: contacts_raw, deals_raw, ad_clicks_raw, ad_campaigns_raw

SELECT * FROM contacts_raw;

-- ── CONTACTS ──────────────────────────────────────────────

-- Total row count
SELECT COUNT(*) AS total_records
FROM contacts_raw;

-- Count of Null / missing first or last names
SELECT COUNT(*) AS missing_names
FROM contacts_raw
WHERE "First Name" IS NULL OR "First Name" = ''
   OR "Last Name" IS NULL OR "Last Name" = '';

-- Contacts with Null / missing first or last names
SELECT *
FROM contacts_raw
WHERE "First Name" IS NULL OR "First Name" = ''
   OR "Last Name" IS NULL OR "Last Name" = '';

-- Null / empty emails
SELECT COUNT(Email) AS missing_email
FROM contacts_raw
WHERE email IS NULL OR email = '';

-- Email domain variations
SELECT
    SPLIT_PART("Email", '@', 2) AS domain,
    COUNT(*) AS occurrence_count
FROM contacts_raw
WHERE "Email" IS NOT NULL
  AND "Email" != ''
GROUP BY domain
ORDER BY domain ASC;

-- Count of Contact with Duplicate emails
SELECT COUNT(duplicate_email_count)
FROM (SELECT COUNT(*) AS duplicate_email_count
        FROM contacts_raw
        WHERE "Email" IS NOT NULL AND "Email" != ''
        GROUP BY "Email"
        HAVING COUNT(*) > 1) AS T;

-- Contact Emails with Duplicate emails
SELECT
    "Email",
    COUNT(*) AS duplicate_email_count
FROM contacts_raw
WHERE "Email" IS NOT NULL AND "Email" != ''
GROUP BY "Email"
HAVING COUNT(*) > 1;

-- Lifecycle stage variants
SELECT DISTINCT "Lifecycle Stage" AS lifecycle_stage
FROM contacts_raw;

-- Lead source variants
SELECT DISTINCT "Lead Source" AS lead_source
FROM contacts_raw;

-- Count for Null cities
SELECT COUNT(*) AS missing_city
FROM contacts_raw
WHERE "City" IS NULL OR "City" = '';

-- Contacts with Null cities
SELECT "First Name", "Last Name"
FROM contacts_raw
WHERE "City" IS NULL OR "City" = '';

-- Count of Contacts with Missing phone numbers
SELECT COUNT(*) AS missing_phone
FROM contacts_raw
WHERE "Phone" IS NULL OR "Phone" = '';

-- Contacts with Missing phone numbers
SELECT "First Name", "Last Name"
FROM contacts_raw
WHERE "Phone" IS NULL OR "Phone" = '';

-- Count of Contacts with title missing
SELECT COUNT(*) AS missing_title
FROM contacts_raw
WHERE "Job Title" IS NULL OR "Job Title" = '';

-- Contacts with title missing
SELECT *
FROM contacts_raw
WHERE "Job Title" IS NULL OR "Job Title" = '';

-- ── DEALS ─────────────────────────────────────────────────
SELECT * FROM deals_raw;
-- Total row count
SELECT COUNT(*) AS total_records
FROM deals_raw;

-- Deal stage variants (DISTINCT)
SELECT DISTINCT "Deal Stage" AS deal_stage
FROM deals_raw;

-- Deal type variants (DISTINCT)
SELECT DISTINCT "Deal Type" AS deal_type
FROM deals_raw;

-- Deal type variants (DISTINCT) - Pipeline vs Deal Type column
SELECT DISTINCT "Pipeline" AS deal_type
FROM deals_raw;

-- Amount formatting issues (nulls + non-numeric values)
SELECT COUNT(*) AS amount_formatting_issues
FROM deals_raw
WHERE "Amount" IS NULL OR NOT REGEXP_REPLACE("Amount", '[^0-9.]', '') ~ '^[0-9]+\.?[0-9]*$';

-- Deals with Amount = Null or empty
SELECT *
FROM deals_raw
WHERE "Amount" IS NULL OR Amount = '';

-- Count of Null close dates
SELECT COUNT(*) AS missing_close_date
FROM deals_raw
WHERE "Close Date" IS NULL OR "Close Date" = '';

-- Deals with Null close dates
SELECT * FROM deals_raw
WHERE "Close Date" IS NULL OR "Close Date" = '';

-- Orphaned deals (no associated contact email)
SELECT * FROM deals_raw
WHERE "Associated Contact Email" IS NULL OR "Associated Contact Email" = '';

-- Duplicate deal names
SELECT * FROM deals_raw
WHERE "Deal Name" IN (
    SELECT "Deal Name"
    FROM deals_raw
    GROUP BY "Deal Name"
    HAVING COUNT(*) > 1
)
ORDER BY "Deal Name" ASC;

-- Duplicate deal names with duplicate close dates
SELECT * FROM deals_raw
WHERE "Deal Name" IN (
    SELECT "Deal Name"
    FROM deals_raw
    GROUP BY "Deal Name"
    HAVING COUNT(*) > 1
)
AND "Close Date" IN (
    SELECT "Close Date"
    FROM deals_raw
    GROUP BY "Close Date"
    HAVING COUNT(*) > 1
)
ORDER BY "Deal Name" ASC;

-- Lead source variants across contacts and deals (DISTINCT)
SELECT DISTINCT "Lead Source"
FROM (
    SELECT "Lead Source" FROM contacts_raw
    UNION
    SELECT "Lead Source" FROM deals_raw
)
WHERE "Lead Source" IS NOT NULL
ORDER BY "Lead Source";
