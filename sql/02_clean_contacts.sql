-- SQLBook: Code
-- ============================================================
-- PQI-03: Clean Contacts
-- Purpose: Standardize and deduplicate contacts_raw
-- Input:   contacts_raw
-- Output:  contacts_clean
-- ============================================================

-- ── STEP 1: NORMALIZE EMAILS ──────────────────────────────
-- Lowercase and trim all emails
UPDATE contacts_clean SET Email = TRIM(LOWER(Email));

-- fix email domain typos
UPDATE contacts_clean
SET Email = REPLACE(Email, '@gmail.comm', '@gmail.com')
WHERE Email LIKE '%@gmail.co';

-- ── STEP 2: NORMALIZE PHONE NUMBERS ──────────────────────
-- Strip all non-numeric characters and keep last 10 digits
UPDATE contacts_clean
SET Phone = SUBSTR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    Phone,
    '-', ''),
    ' ', ''),
    '(', ''),
    ')', ''),
    '+', ''),
    '.', ''),
    ' ', ''), -10);

-- Null out anything that can't be salvaged
UPDATE contacts_clean
SET Phone = CASE
    WHEN Phone LIKE '1%' THEN NULL
    WHEN Phone LIKE '0%' THEN NULL
    WHEN LENGTH(Phone) < 10 THEN NULL
    ELSE Phone
END;

-- ── STEP 3: NORMALIZE LEAD SOURCE ────────────────────────
-- Standardize all variants to canonical values
-- YouTube, Podcast, Paid Social, Events,
-- Referral, Newsletter, Organic Search, Unknown
UPDATE contacts_clean
SET "Lead Source" = CASE
WHEN "Lead Source" ILIKE '%youtube%' THEN 'YouTube'
    WHEN "Lead Source" ILIKE '%podcast%' THEN 'Podcast'
    WHEN "Lead Source" ILIKE '%paid social%' THEN 'Paid Social'
    WHEN "Lead Source" ILIKE '%event%' THEN 'Events'
    WHEN "Lead Source" ILIKE '%referral%' THEN 'Referral'
    WHEN "Lead Source" ILIKE '%newsletter%' THEN 'Newsletter'
    WHEN "Lead Source" ILIKE '%organic search%' THEN 'Organic Search'
    ELSE 'Unknown'
END;

-- ── STEP 4: NORMALIZE LIFECYCLE STAGE ────────────────────
-- Standardize all variants to canonical values
-- Lead, MQL, SQL, Opportunity, Customer,
-- Subscriber, Unknown

UPDATE contacts_clean
SET "Lifecycle Stage" = CASE
 WHEN "Lifecycle Stage" ILIKE '%lead%' THEN 'Lead'
        WHEN "Lifecycle Stage" ILIKE '%mql%' THEN 'MQL'
        WHEN "Lifecycle Stage" ILIKE '%sql%' THEN 'SQL'
        WHEN "Lifecycle Stage" ILIKE '%opportunity%' THEN 'Opportunity'
        WHEN "Lifecycle Stage" ILIKE '%customer%' THEN 'Customer'
        WHEN "Lifecycle Stage" ILIKE '%subscriber%' THEN 'Subscriber'
        ELSE 'Unknown'
END;
-- ── STEP 5: NORMALIZE COMPANY ────────────────────────────
-- Trim whitespace
SELECT TRIM("Company"), Company FROM contacts_raw;

-- Remove trailing LLC variants (optional)
UPDATE contacts_clean
SET Company = TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Company,
    ' LLC LLC LLC', ' LLC'),
    ' LLC, LLC', ' LLC'),
    ' LLC LLC', ' LLC'),
    '  ', ' '))
WHERE Company LIKE '% LLC%LLC%';

-- Fix capitalization
UPDATE contacts_clean
SET Company = array_to_string(
    list_transform(
        string_split(Company, ' '),
        word -> CASE
            WHEN regexp_replace(word, ',$', '') = 'AND' THEN lower(word)
            WHEN regexp_replace(word, ',$', '') IN ('LLC', 'PLC') THEN word
            ELSE array_to_string(
                list_transform(
                    string_split(word, '-'),
                    part -> upper(part[1:1]) || lower(part[2:])
                ),
                '-'
            )
        END
    ),
    ' '
)
WHERE Company IS NOT NULL;

-- ── STEP 6: HANDLE NULLS ─────────────────────────────────
-- Null out empty strings for city and job title
UPDATE contacts_clean SET "Job Title" = NULL
WHERE "Job Title" IS NULL OR "Job Title" = '';

UPDATE contacts_clean SET City = NULL
WHERE City IS NULL OR City = '';

-- Flag records with missing first or last name
-- ── STEP 7: DEDUPLICATE ───────────────────────────────────
-- Identify duplicate emails (case-insensitive)
-- Keep most recent record per email
-- Use ROW_NUMBER() OVER PARTITION BY