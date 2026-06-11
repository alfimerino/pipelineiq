-- SQLBook: Code
-- PQI-02: Data Audit
-- Purpose: Discover all data quality issues before cleaning
-- Tables: contacts_raw, deals_raw, ad_clicks_raw, ad_campaigns_raw

-- ── CONTACTS ──────────────────────────────────────────────

-- Total row count
SELECT
    COUNT(*) AS total_records
FROM contacts_raw;

-- Null / empty emails
SELECT
    COUNT(Email) AS missing_email
FROM contacts_raw
WHERE email IS NULL OR email = '';

-- Duplicate emails
SELECT
    Email,
    COUNT(*) AS duplicate_email_count
FROM contacts_raw
WHERE email IS NOT NULL AND email != ''
GROUP BY Email
HAVING COUNT(*) > 1;

-- Lifecycle stage variants
SELECT DISTINCT "Lifecycle Stage" AS lifecycle_stage FROM contacts_raw;

-- Lead source variants
SELECT DISTINCT "Lead Source" AS lead_source FROM contacts_raw;

-- Null cities

SELECT COUNT(*) AS missing_city
FROM contacts_raw
WHERE city IS NULL OR city = '';

SELECT "First Name", "Last Name" FROM contacts_raw
WHERE city IS NULL OR city = '';

-- Phone format chaos
SELECT COUNT(*) AS missing_phone
FROM contacts_raw
WHERE phone IS NULL OR phone = '';

SELECT "First Name", "Last Name" FROM contacts_raw
WHERE phone IS NULL OR phone = '';
