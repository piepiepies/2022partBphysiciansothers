IF OBJECT_ID('original_data') IS NOT NULL
	DROP TABLE original_data
GO

CREATE TABLE original_data (
	provider_npi int,
	provider_last_name varchar(MAX),
	provider_first_name varchar(50),
	provider_middle varchar(50),
	provider_credentials varchar(50),
	provider_gender varchar(50),
	provider_entity_type varchar(50),
	provider_st1 varchar(MAX),
	provider_st2 varchar(MAX),
	provider_city varchar(50),
	provider_state varchar(50),
	provider_state_fips varchar(50),
	provider_zip varchar(50),
	provider_ruca varchar(50),
	provider_ruca_desc varchar(150),
	provider_country varchar(50),
	provider_type varchar(MAX),
	provider_medicare_participation varchar(50),
	hcpcs_code varchar(50),
	hcpcs_desc varchar(MAX),
	hcpcs_drug_indicator varchar(50),
	place_of_service varchar(50),
	total_beneficiaries varchar(50),
	total_services varchar(50),
	total_beneficiaries_per_day_services varchar(50),
	avg_submitted_charge varchar(50),
	avg_medicare_allowed_amt varchar(50),
	avg_medicare_payment_amt varchar(50),
	avg_medicare_standardized_amount varchar(50)
)
GO

BULK INSERT original_data
FROM 'C:\Users\Ray\Desktop\Medicare_Physician_Other_Practitioners_by_Provider_and_Service_2022 (1)\Medicare_Physician_Other_Practitioners_by_Provider_and_Service_2022.csv'
WITH(
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a'
)
GO