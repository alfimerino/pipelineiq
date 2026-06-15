-- ============================================================
-- PQI-04: Clean Deals
-- Purpose: Standardize and deduplicate deals_raw
-- Input:   deals_raw
-- Output:  deals_clean
-- ============================================================

-- Make a copy of deals_raw to work with called deals_clean
CREATE TABLE deals_clean AS
SELECT * FROM deals_raw;

-- ── STEP 1: NORMALIZE DEAL STAGE ─────────────────────────
-- Check distinct values to identify variants and typos
SELECT DISTINCT "Deal Stage" FROM deals_clean
ORDER BY "Deal Stage" ASC;

-- Run this query to test the CASE statement below before applying the update
SELECT "Deal Stage",
CASE
    WHEN "Deal Stage" ILIKE '%disco%' THEN 'Discovery'
    WHEN "Deal Stage" ILIKE '%qual%' THEN 'Qualified'
    WHEN "Deal Stage" ILIKE '%Nego%' THEN 'Negotiation'
    WHEN "Deal Stage" ILIKE '%prop%' THEN 'Proposal Sent'
    WHEN "Deal Stage" ILIKE '%Won%' THEN 'Closed Won'
    WHEN "Deal Stage" ILIKE '%los%' THEN 'Closed Lost'
    ELSE 'Unknown'
END AS "Deal Stage Clean"
FROM deals_clean
ORDER BY "Deal Stage" ASC;

-- After verifying the mapping, run the update to clean the Deal Stage
UPDATE deals_clean
SET "Deal Stage" = CASE
    WHEN "Deal Stage" ILIKE '%disco%' THEN 'Discovery'
    WHEN "Deal Stage" ILIKE '%qual%' THEN 'Qualified'
    WHEN "Deal Stage" ILIKE '%Nego%' THEN 'Negotiation'
    WHEN "Deal Stage" ILIKE '%prop%' THEN 'Proposal Sent'
    WHEN "Deal Stage" ILIKE '%Won%' THEN 'Closed Won'
    WHEN "Deal Stage" ILIKE '%los%' THEN 'Closed Lost'
    ELSE 'Unknown'
END;

-- ── STEP 2: NORMALIZE DEAL TYPE ──────────────────────────
-- Standardize all variants to canonical values
-- Podcast Sponsorship, Brand Partnership
-- Consulting Engagement, Event Tickets / VIP
-- Course / Education, Other

-- ── STEP 3: NORMALIZE LEAD SOURCE ────────────────────────
-- Same canonical values as contacts_clean
-- YouTube, Podcast, Paid Social, Events,
-- Referral, Newsletter, Organic Search, Unknown

-- ── STEP 4: CLEAN AMOUNT ─────────────────────────────────
-- Strip $ signs and commas
-- Cast to numeric (DECIMAL or DOUBLE)
-- Null out anything that cant be cast

-- ── STEP 5: NORMALIZE DATES ──────────────────────────────
-- Standardize Close Date and Create Date
-- Handle all 5 format variants from the audit
-- Null out future create dates (data entry errors)
-- Null out missing close dates on open deals

-- ── STEP 6: HANDLE ORPHANED DEALS ────────────────────────
-- Flag deals with no Associated Contact Email
-- Decide: exclude or keep with null contact

-- ── STEP 7: DEDUPLICATE ───────────────────────────────────
-- Identify duplicate deal name + stage + contact email
-- Keep most recent record
-- Use ROW_NUMBER() OVER PARTITION BY
