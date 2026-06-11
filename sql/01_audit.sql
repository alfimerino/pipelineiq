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