-- provider information table creation
IF OBJECT_id('provider_information') IS NOT NULL
	DROP TABLE provider_information
GO

SELECT DISTINCT 
	provider_npi, provider_last_name, provider_first_name,
	provider_middle, provider_credentials, provider_gender,
	provider_entity_type, provider_st1,	provider_st2,
	provider_city, provider_state, provider_state_fips, 
	provider_zip, provider_ruca, provider_country, provider_type
INTO provider_information
FROM dbo.original_data
GO

-- ruca information table creation 
IF OBJECT_id('ruca_information') IS NOT NULL
	DROP TABLE ruca_information
GO

SELECT DISTINCT provider_ruca, provider_ruca_desc
INTO ruca_information
FROM dbo.original_data
GO


-- hcpcs information table creation
IF OBJECT_id('hcpcs_information') IS NOT NULL
	DROP TABLE hcpcs_information
GO

SELECT DISTINCT hcpcs_code, hcpcs_desc, hcpcs_drug_indicator
INTO hcpcs_information
FROM dbo.original_data
GO

-- payment information table creation
-- could also go with ALTER TABLE DROP COLUMN column names on the original data, but i want to keep it.
IF OBJECT_id('payment_information') IS NOT NULL
	DROP TABLE payment_information
GO

SELECT
	provider_npi, provider_medicare_participation, hcpcs_code, place_of_service,
	total_beneficiaries, total_services, total_beneficiaries_per_day_services,
	avg_submitted_charge, avg_medicare_allowed_amt, avg_medicare_payment_amt, avg_medicare_standardized_amount
INTO payment_information
FROM dbo.original_data
GO

