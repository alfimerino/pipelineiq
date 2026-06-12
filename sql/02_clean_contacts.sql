-- SQLBook: Code
-- ============================================================
-- PQI-03: Clean Contacts
-- Purpose: Standardize and deduplicate contacts_raw
-- Input:   contacts_raw
-- Output:  contacts_clean
-- ============================================================

-- ── STEP 1: NORMALIZE EMAILS ──────────────────────────────
-- Lowercase and trim all emails
SELECT TRIM(LOWER(Email)) FROM contacts_raw;

-- Flag invalid emails (no @ or typo domains)
SELECT Email,
    CASE
        WHEN Email LIKE '%@gmail.co%' THEN 'Invalid: co'
        WHEN Email LIKE '%@yaho.com%' THEN 'Invalid: yahoo'
        ELSE 'Valid'
END AS email_validity
FROM contacts_raw;

-- ── STEP 2: NORMALIZE PHONE NUMBERS ──────────────────────
-- Strip all non-numeric characters
-- Keep last 10 digits
-- Null out anything that can't be salvaged
-- ── STEP 3: NORMALIZE LEAD SOURCE ────────────────────────
-- Standardize all variants to canonical values
-- YouTube, Podcast, Paid Social, Events,
-- Referral, Newsletter, Organic Search, Unknown
-- ── STEP 4: NORMALIZE LIFECYCLE STAGE ────────────────────
-- Standardize all variants to canonical values
-- Lead, MQL, SQL, Opportunity, Customer,
-- Subscriber, Unknown
-- ── STEP 5: NORMALIZE COMPANY ────────────────────────────
-- Trim whitespace
-- Remove trailing LLC variants (optional)
-- ── STEP 6: HANDLE NULLS ─────────────────────────────────
-- Null out empty strings for city and job title
-- Flag records with missing first or last name
-- ── STEP 7: DEDUPLICATE ───────────────────────────────────
-- Identify duplicate emails (case-insensitive)
-- Keep most recent record per email
-- Use ROW_NUMBER() OVER PARTITION BY
-- ── STEP 8: CREATE CLEAN TABLE ───────────────────────────
-- CREATE TABLE contacts_clean AS
-- SELECT all normalized fields
-- Apply all transformations above
-- Exclude duplicates
-- ── STEP 9: VALIDATE ─────────────────────────────────────
-- Count before vs after
-- Confirm no nulls in email
-- Confirm no duplicate emails
-- Confirm all lifecycle stages are canonical
-- Confirm all lead sources are canonical